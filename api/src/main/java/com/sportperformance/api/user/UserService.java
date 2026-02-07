package com.sportperformance.api.user;

import com.sportperformance.api.common.ResourceConflictException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User createUser(String email, String role, UUID academyId, String userNumber) {
        if (userRepository.existsByEmail(email)) {
            throw new ResourceConflictException("User with email " + email + " already exists");
        }

        if (userNumber != null && userRepository.existsByUserNumber(userNumber)) {
            throw new ResourceConflictException("User with number " + userNumber + " already exists");
        }

        String finalUserNumber = userNumber != null ? userNumber : generateUserNumber();

        User user = new User(
            UUID.randomUUID(),
            finalUserNumber,
            academyId,
            email,
            role,
            true,
            OffsetDateTime.now()
        );

        return userRepository.save(user);
    }

    public User getOrCreateUser(String email, String role, UUID academyId) {
        return userRepository.findByEmail(email)
            .orElseGet(() -> createUser(email, role, academyId, null));
    }

    private String generateUserNumber() {
        return "USR-" + System.currentTimeMillis();
    }
}
