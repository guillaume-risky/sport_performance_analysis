package com.sportperformance.api.academy;

public record AcademyResponse(
    Long academyNumber,
    String name,
    String logoUrl,
    String primaryColor
) {}
