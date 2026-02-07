package com.sportperformance.api.invite;

import com.sportperformance.api.academy.AcademyRepository;
import com.sportperformance.api.academy.Academy;
import com.sportperformance.api.common.InvalidInviteException;
import com.sportperformance.api.common.ResourceNotFoundException;
import com.sportperformance.api.user.User;
import com.sportperformance.api.user.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.Base64;
import java.util.UUID;

@Service
public class InviteService {

    private final InviteRepository inviteRepository;
    private final AcademyRepository academyRepository;
    private final UserService userService;
    private static final SecureRandom random = new SecureRandom();

    public InviteService(
            InviteRepository inviteRepository,
            AcademyRepository academyRepository,
            UserService userService) {
        this.inviteRepository = inviteRepository;
        this.academyRepository = academyRepository;
        this.userService = userService;
    }

    @Transactional
    public InviteResponse createInvite(InviteRequest request) {
        Academy academy = academyRepository.findByAcademyNumber(request.academyNumber())
            .orElseThrow(() -> new ResourceNotFoundException("Academy with number " + request.academyNumber() + " not found"));

        if (!isValidRole(request.role())) {
            throw new InvalidInviteException("Invalid role. Must be one of: ACADEMY_ADMIN, COACH, PLAYER");
        }

        String token = generateToken();
        OffsetDateTime expiresAt = OffsetDateTime.now().plusHours(request.expiresInHours());

        InviteToken inviteToken = new InviteToken(
            UUID.randomUUID(),
            token,
            academy.id(),
            request.email(),
            request.role(),
            expiresAt,
            null,
            OffsetDateTime.now()
        );

        inviteRepository.save(inviteToken);

        String inviteUrl = "http://localhost:8080/invite/" + token;

        return new InviteResponse(token, inviteUrl, expiresAt);
    }

    public InviteToken getInviteByToken(String token) {
        InviteToken inviteToken = inviteRepository.findByToken(token)
            .orElseThrow(() -> new InvalidInviteException("Invalid invite token"));

        if (inviteToken.usedAt() != null) {
            throw new InvalidInviteException("Invite token has already been used");
        }

        if (inviteToken.expiresAt().isBefore(OffsetDateTime.now())) {
            throw new InvalidInviteException("Invite token has expired");
        }

        return inviteToken;
    }

    @Transactional
    public AcceptInviteResponse acceptInvite(String token, AcceptInviteRequest request) {
        InviteToken inviteToken = getInviteByToken(token);

        if (!inviteToken.email().equalsIgnoreCase(request.email())) {
            throw new InvalidInviteException("Email does not match the invite");
        }

        User user = userService.getOrCreateUser(
            inviteToken.email(),
            inviteToken.role(),
            inviteToken.academyId()
        );

        inviteRepository.markAsUsed(inviteToken.id(), OffsetDateTime.now());

        return new AcceptInviteResponse(user.userNumber(), user.role());
    }

    private String generateToken() {
        byte[] bytes = new byte[60];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private boolean isValidRole(String role) {
        return role != null && (role.equals("ACADEMY_ADMIN") || role.equals("COACH") || role.equals("PLAYER"));
    }
}
