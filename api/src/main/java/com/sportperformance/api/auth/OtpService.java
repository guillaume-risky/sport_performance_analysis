package com.sportperformance.api.auth;

import com.sportperformance.api.security.AppRole;
import com.sportperformance.api.security.JwtService;
import com.sportperformance.api.security.SecurityUserPrincipal;
import com.sportperformance.api.security.SessionStore;
import com.sportperformance.api.user.User;
import com.sportperformance.api.user.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;

@Service
public class OtpService {

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);
    private static final SecureRandom random = new SecureRandom();
    private static final int OTP_LENGTH = 6;

    private final OtpChallengeRepository repository;
    private final OtpDeliveryService deliveryService;
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final SessionStore sessionStore;
    private final int otpTtlMinutes;

    public OtpService(
            OtpChallengeRepository repository,
            OtpDeliveryService deliveryService,
            UserRepository userRepository,
            JwtService jwtService,
            SessionStore sessionStore,
            @Value("${app.auth.otpTtlMinutes:10}") int otpTtlMinutes) {
        this.repository = repository;
        this.deliveryService = deliveryService;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.sessionStore = sessionStore;
        this.otpTtlMinutes = otpTtlMinutes;
    }

    @Transactional
    public void requestOtp(String email, String purpose) {
        try {
            String otp = generateOtp();
            String codeHash = hashOtp(otp);
            OffsetDateTime expiresAt = OffsetDateTime.now().plusMinutes(otpTtlMinutes);

            OtpChallenge challenge = new OtpChallenge(
                UUID.randomUUID(),
                email,
                purpose,
                codeHash,
                expiresAt,
                0,
                false,
                OffsetDateTime.now()
            );

            repository.save(challenge);
            deliveryService.sendOtp(email, otp, purpose);
        } catch (Exception e) {
            log.error("Failed to request OTP for email={}, purpose={}", email, purpose, e);
            throw new RuntimeException("Failed to request OTP", e);
        }
    }

    @Transactional
    public OtpVerifyResult verifyOtp(String email, String purpose, String otp, String correlationId) {
        String providedHash = hashOtp(otp);
        log.info("OTP verify started [correlationId={}, email={}, purpose={}, otpHash={}]", 
            correlationId, email, purpose, providedHash);

        try {
            Optional<OtpChallenge> challengeOpt = repository.findByEmailAndPurpose(email, purpose);
            
            if (challengeOpt.isEmpty()) {
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=NOT_FOUND]", 
                    correlationId, email, purpose, providedHash);
                throw new InvalidOtpException("OTP challenge not found for email and purpose");
            }

            OtpChallenge challenge = challengeOpt.get();

            if (challenge.consumed()) {
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=USED]", 
                    correlationId, email, purpose, providedHash);
                throw new OtpAlreadyUsedException("OTP has already been used");
            }

            if (!challenge.purpose().equals(purpose)) {
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=INVALID]", 
                    correlationId, email, purpose, providedHash);
                throw new InvalidOtpException("Purpose mismatch");
            }

            OffsetDateTime now = OffsetDateTime.now();
            if (challenge.expiresAt().isBefore(now)) {
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=EXPIRED]", 
                    correlationId, email, purpose, providedHash);
                throw new ExpiredOtpException("OTP has expired");
            }

            if (!providedHash.equals(challenge.codeHash())) {
                int newAttempts = challenge.attempts() + 1;
                OtpChallenge updatedChallenge = new OtpChallenge(
                    challenge.id(),
                    challenge.email(),
                    challenge.purpose(),
                    challenge.codeHash(),
                    challenge.expiresAt(),
                    newAttempts,
                    challenge.consumed(),
                    challenge.createdAt()
                );
                repository.save(updatedChallenge);
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=INVALID]", 
                    correlationId, email, purpose, providedHash);
                throw new InvalidOtpException("Invalid OTP code");
            }

            Optional<User> userOpt = userRepository.findByEmail(email);
            if (userOpt.isEmpty()) {
                log.warn("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=NOT_FOUND]", 
                    correlationId, email, purpose, providedHash);
                throw new UserNotFoundException("User not found for email: " + email);
            }

            User user = userOpt.get();

            OtpChallenge consumedChallenge = new OtpChallenge(
                challenge.id(),
                challenge.email(),
                challenge.purpose(),
                challenge.codeHash(),
                challenge.expiresAt(),
                challenge.attempts(),
                true,
                challenge.createdAt()
            );
            repository.save(consumedChallenge);

            AppRole role;
            try {
                role = AppRole.valueOf(user.role());
            } catch (IllegalArgumentException e) {
                log.error("Invalid role value [correlationId={}, userId={}, role={}]", 
                    correlationId, user.id(), user.role(), e);
                throw new RuntimeException("Invalid user role: " + user.role(), e);
            }
            
            String academyNumberStr = user.academyNumber() != null ? user.academyNumber().toString() : null;
            SecurityUserPrincipal principal = new SecurityUserPrincipal(
                user.id(),
                user.userNumber(),
                user.email(),
                academyNumberStr,
                role
            );
            
            JwtService.IssuedToken jwtToken;
            try {
                jwtToken = jwtService.issue(principal);
            } catch (Exception e) {
                log.error("Failed to issue JWT token [correlationId={}, userId={}]", correlationId, user.id(), e);
                throw new RuntimeException("Failed to issue JWT token", e);
            }
            
            try {
                sessionStore.create(user.id(), jwtToken.jwtId(), jwtToken.expiresAt());
            } catch (Exception e) {
                log.error("Failed to create session [correlationId={}, userId={}, jwtId={}]", 
                    correlationId, user.id(), jwtToken.jwtId(), e);
                throw new RuntimeException("Failed to create session", e);
            }
            
            log.info("OTP verify outcome [correlationId={}, email={}, purpose={}, otpHash={}, outcome=SUCCESS]", 
                correlationId, email, purpose, providedHash);
            
            return new OtpVerifyResult(true, jwtToken.token(), user.userNumber().toString());
        } catch (InvalidOtpException | ExpiredOtpException | OtpAlreadyUsedException | UserNotFoundException e) {
            throw e;
        } catch (Exception e) {
            log.error("OTP verify unexpected error [correlationId={}, email={}, purpose={}, otpHash={}]", 
                correlationId, email, purpose, providedHash, e);
            throw new RuntimeException("Failed to verify OTP", e);
        }
    }

    public record OtpVerifyResult(boolean success, String accessToken, String userNumber) {}

    private String generateOtp() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    private String hashOtp(String otp) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(otp.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
