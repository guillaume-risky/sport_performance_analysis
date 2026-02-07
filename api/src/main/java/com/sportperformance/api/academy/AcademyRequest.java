package com.sportperformance.api.academy;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record AcademyRequest(
    @NotBlank(message = "academyNumber is required")
    @Size(max = 30, message = "academyNumber must not exceed 30 characters")
    String academyNumber,

    @NotBlank(message = "name is required")
    @Size(max = 120, message = "name must not exceed 120 characters")
    String name,

    @Size(max = 20, message = "themeColor must not exceed 20 characters")
    String themeColor,

    String logoUrl
) {}
