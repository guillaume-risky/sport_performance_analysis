package com.sportperformance.api.invite;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record InviteRequest(
    @NotBlank(message = "academyNumber is required")
    String academyNumber,

    @NotBlank(message = "email is required")
    @Email(message = "email must be valid")
    String email,

    @NotBlank(message = "role is required")
    String role,

    @NotNull(message = "expiresInHours is required")
    @Positive(message = "expiresInHours must be positive")
    Integer expiresInHours
) {}
