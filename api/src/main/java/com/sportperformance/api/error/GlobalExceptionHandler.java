package com.sportperformance.api.error;

import com.sportperformance.api.academy.AcademyNotFoundException;
import com.sportperformance.api.academy.AcademyNotSetException;
import com.sportperformance.api.auth.ExpiredOtpException;
import com.sportperformance.api.auth.InvalidOtpException;
import com.sportperformance.api.auth.OtpAlreadyUsedException;
import com.sportperformance.api.auth.UserNotFoundException;
import com.sportperformance.api.common.ErrorResponse;
import com.sportperformance.api.common.InvalidInviteException;
import com.sportperformance.api.common.ResourceConflictException;
import com.sportperformance.api.common.ResourceNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    private String getOrGenerateCorrelationId(WebRequest request) {
        RequestAttributes requestAttributes = RequestContextHolder.getRequestAttributes();
        if (requestAttributes instanceof ServletRequestAttributes) {
            HttpServletRequest httpRequest = ((ServletRequestAttributes) requestAttributes).getRequest();
            if (httpRequest != null) {
                String correlationId = httpRequest.getHeader("X-Correlation-ID");
                if (correlationId != null && !correlationId.isBlank()) {
                    return correlationId;
                }
            }
        }
        return UUID.randomUUID().toString();
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationExceptions(
            MethodArgumentNotValidException ex, WebRequest request) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        String message = "Validation failed: " + errors.toString();
        String correlationId = getOrGenerateCorrelationId(request);
        ErrorResponse errorResponse = new ErrorResponse(
            "VALIDATION_ERROR",
            message,
            request.getDescription(false).replace("uri=", ""),
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolationException(
            ConstraintViolationException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        ErrorResponse errorResponse = new ErrorResponse(
            "VALIDATION_ERROR",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", ""),
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoResourceFoundException(
            NoResourceFoundException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.warn("No resource found [correlationId={}, path={}, resourcePath={}]", 
            correlationId, path, ex.getResourcePath());
        
        ErrorResponse errorResponse = new ErrorResponse(
            "NOT_FOUND",
            "Resource not found: " + ex.getResourcePath(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
            ResourceNotFoundException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        ErrorResponse errorResponse = new ErrorResponse(
            "NOT_FOUND",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", ""),
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(ResourceConflictException.class)
    public ResponseEntity<ErrorResponse> handleResourceConflictException(
            ResourceConflictException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        ErrorResponse errorResponse = new ErrorResponse(
            "CONFLICT",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", ""),
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(InvalidInviteException.class)
    public ResponseEntity<ErrorResponse> handleInvalidInviteException(
            InvalidInviteException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        ErrorResponse errorResponse = new ErrorResponse(
            "INVALID_INVITE",
            ex.getMessage(),
            request.getDescription(false).replace("uri=", ""),
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(InvalidOtpException.class)
    public ResponseEntity<ErrorResponse> handleInvalidOtpException(
            InvalidOtpException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.error("Invalid OTP exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "INVALID_OTP",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(ExpiredOtpException.class)
    public ResponseEntity<ErrorResponse> handleExpiredOtpException(
            ExpiredOtpException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.error("Expired OTP exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "INVALID_OTP",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(OtpAlreadyUsedException.class)
    public ResponseEntity<ErrorResponse> handleOtpAlreadyUsedException(
            OtpAlreadyUsedException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.error("OTP already used exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "CONFLICT",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFoundException(
            UserNotFoundException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.error("User not found exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "NOT_FOUND",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(AcademyNotSetException.class)
    public ResponseEntity<ErrorResponse> handleAcademyNotSetException(
            AcademyNotSetException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.warn("Academy not set exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "ACADEMY_NOT_SET",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(AcademyNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleAcademyNotFoundException(
            AcademyNotFoundException ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.warn("Academy not found exception [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "ACADEMY_NOT_FOUND",
            ex.getMessage(),
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, WebRequest request) {
        String correlationId = getOrGenerateCorrelationId(request);
        String path = request.getDescription(false).replace("uri=", "");
        
        log.error("Internal error occurred [correlationId={}, path={}]", correlationId, path, ex);
        
        ErrorResponse errorResponse = new ErrorResponse(
            "INTERNAL_ERROR",
            "An unexpected error occurred",
            path,
            correlationId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
