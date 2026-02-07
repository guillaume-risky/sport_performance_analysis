package com.sportperformance.api.academy;

import jakarta.validation.constraints.NotBlank;

public record AcademyRequest(
    @NotBlank(message = "Name is required")
    String name,
    String logoUrl,
    String primaryColor
) {}
