package com.sportperformance.api.academy;

import java.time.OffsetDateTime;
import java.util.UUID;

public record AcademyResponse(
    UUID id,
    String academyNumber,
    String name,
    String themeColor,
    String logoUrl,
    OffsetDateTime createdAt
) {}
