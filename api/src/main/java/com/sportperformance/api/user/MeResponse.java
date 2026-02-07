package com.sportperformance.api.user;

public record MeResponse(
    Long userNumber,
    String email,
    String role,
    Long academyNumber
) {}
