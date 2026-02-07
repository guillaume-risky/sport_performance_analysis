package com.sportperformance.api.user;

import java.time.OffsetDateTime;

public record User(
    Long id,
    Long userNumber,
    String email,
    String role,
    Boolean isActive,
    Long academyNumber,
    OffsetDateTime createdAt
) {}
