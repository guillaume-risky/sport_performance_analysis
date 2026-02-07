package com.sportperformance.api.common;

import java.time.OffsetDateTime;

public record ErrorResponse(
    String error,
    String message,
    String path,
    OffsetDateTime timestamp
) {
    public ErrorResponse(String error, String message, String path) {
        this(error, message, path, OffsetDateTime.now());
    }
}
