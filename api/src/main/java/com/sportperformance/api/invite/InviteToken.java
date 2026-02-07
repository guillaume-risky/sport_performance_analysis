package com.sportperformance.api.invite;

import java.time.OffsetDateTime;
import java.util.UUID;

public record InviteToken(
    UUID id,
    String token,
    UUID academyId,
    String email,
    String role,
    OffsetDateTime expiresAt,
    OffsetDateTime usedAt,
    OffsetDateTime createdAt
) {}
