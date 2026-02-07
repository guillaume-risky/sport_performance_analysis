package com.sportperformance.api.invite;

import java.time.OffsetDateTime;

public record InviteResponse(
    String token,
    String inviteUrl,
    OffsetDateTime expiresAt
) {}
