package com.sportperformance.api.academy;

import com.sportperformance.api.security.AppRole;
import com.sportperformance.api.security.SecurityUserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/academies")
public class AcademyController {

    private final AcademyService academyService;

    public AcademyController(AcademyService academyService) {
        this.academyService = academyService;
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('ACADEMY_ADMIN')")
    public ResponseEntity<AcademyResponse> createAcademy(@Valid @RequestBody AcademyRequest request) {
        Academy academy = academyService.createAcademy(
            request.name(),
            request.logoUrl(),
            request.primaryColor()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(new AcademyResponse(
            academy.academyNumber(),
            academy.name(),
            academy.logoUrl(),
            academy.primaryColor()
        ));
    }

    @GetMapping(value = "/me", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<AcademyResponse> getMyAcademy() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        SecurityUserPrincipal principal = (SecurityUserPrincipal) auth.getPrincipal();

        if (principal.academyNumber() == null || principal.academyNumber().isBlank()) {
            throw new AcademyNotSetException("User does not have an academy assigned");
        }

        Long academyNumber = Long.parseLong(principal.academyNumber());
        Academy academy = academyService.findByAcademyNumber(academyNumber);

        return ResponseEntity.ok(new AcademyResponse(
            academy.academyNumber(),
            academy.name(),
            academy.logoUrl(),
            academy.primaryColor()
        ));
    }
}
