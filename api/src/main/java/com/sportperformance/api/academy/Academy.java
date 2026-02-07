package com.sportperformance.api.academy;

import java.time.OffsetDateTime;

public record Academy(
    Long id,
    Long academyNumber,
    String name,
    String logoUrl,
    String primaryColor,
    OffsetDateTime createdAt
) {}
