package com.sportperformance.api.user;

import com.sportperformance.api.common.ResourceConflictException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User createUser(String email, String role, Long userNumber) {
        if (userRepository.existsByEmail(email)) {
            throw new ResourceConflictException("User with email " + email + " already exists");
        }

        if (userNumber != null && userRepository.existsByUserNumber(userNumber)) {
            throw new ResourceConflictException("User with number " + userNumber + " already exists");
        }

        Long finalUserNumber = userNumber != null ? userNumber : generateUserNumber();

        User user = new User(
            null,
            finalUserNumber,
            email,
            role,
            true,
            null, // academyNumber
            OffsetDateTime.now()
        );

        return userRepository.save(user);
    }

    public User getOrCreateUser(String email, String role) {
        return userRepository.findByEmail(email)
            .orElseGet(() -> createUser(email, role, null));
    }

    private Long generateUserNumber() {
        return System.currentTimeMillis();
    }
}
