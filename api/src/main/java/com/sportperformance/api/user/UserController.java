package com.sportperformance.api.user;

import com.sportperformance.api.security.SecurityUserPrincipal;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<MeResponse> getMe() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        SecurityUserPrincipal principal = (SecurityUserPrincipal) auth.getPrincipal();

        return ResponseEntity.ok(new MeResponse(
            principal.userNumber(),
            principal.email(),
            principal.role().name(),
            principal.academyNumber() != null && !principal.academyNumber().isBlank() 
                ? Long.parseLong(principal.academyNumber()) 
                : null
        ));
    }
}
