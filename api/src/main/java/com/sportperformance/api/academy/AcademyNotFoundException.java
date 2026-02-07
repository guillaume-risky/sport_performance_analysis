package com.sportperformance.api.academy;

public class AcademyNotFoundException extends RuntimeException {
    public AcademyNotFoundException(String message) {
        super(message);
    }
}
