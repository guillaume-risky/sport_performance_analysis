package com.sportperformance.api.user;

import java.time.OffsetDateTime;
import java.util.UUID;

public record User(
    UUID id,
    String userNumber,
    UUID academyId,
    String email,
    String role,
    Boolean isActive,
    OffsetDateTime createdAt
) {}
