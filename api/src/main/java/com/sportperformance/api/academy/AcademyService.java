package com.sportperformance.api.academy;

import com.sportperformance.api.common.ResourceConflictException;
import com.sportperformance.api.common.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class AcademyService {

    private final AcademyRepository academyRepository;

    public AcademyService(AcademyRepository academyRepository) {
        this.academyRepository = academyRepository;
    }

    @Transactional
    public AcademyResponse createAcademy(AcademyRequest request) {
        if (academyRepository.existsByAcademyNumber(request.academyNumber())) {
            throw new ResourceConflictException("Academy with number " + request.academyNumber() + " already exists");
        }

        Academy academy = new Academy(
            UUID.randomUUID(),
            request.academyNumber(),
            request.name(),
            request.themeColor(),
            request.logoUrl(),
            OffsetDateTime.now()
        );

        Academy saved = academyRepository.save(academy);
        return toResponse(saved);
    }

    public AcademyResponse getAcademyByNumber(String academyNumber) {
        Academy academy = academyRepository.findByAcademyNumber(academyNumber)
            .orElseThrow(() -> new ResourceNotFoundException("Academy with number " + academyNumber + " not found"));
        return toResponse(academy);
    }

    private AcademyResponse toResponse(Academy academy) {
        return new AcademyResponse(
            academy.id(),
            academy.academyNumber(),
            academy.name(),
            academy.themeColor(),
            academy.logoUrl(),
            academy.createdAt()
        );
    }
}
