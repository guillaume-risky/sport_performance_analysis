package com.sportperformance.api.academy;

import com.sportperformance.api.common.ResourceConflictException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.OffsetDateTime;

@Service
public class AcademyService {

    private final AcademyRepository academyRepository;
    private static final SecureRandom random = new SecureRandom();

    public AcademyService(AcademyRepository academyRepository) {
        this.academyRepository = academyRepository;
    }

    @Transactional
    public Academy createAcademy(String name, String logoUrl, String primaryColor) {
        Long academyNumber = generateUniqueAcademyNumber();
        
        Academy academy = new Academy(
            null,
            academyNumber,
            name,
            logoUrl,
            primaryColor,
            OffsetDateTime.now()
        );

        return academyRepository.save(academy);
    }

    public Academy findByAcademyNumber(Long academyNumber) {
        return academyRepository.findByAcademyNumber(academyNumber)
            .orElseThrow(() -> new AcademyNotFoundException("Academy with number " + academyNumber + " not found"));
    }

    private Long generateUniqueAcademyNumber() {
        int maxAttempts = 10;
        for (int i = 0; i < maxAttempts; i++) {
            long number = 100000000L + random.nextLong(900000000L);
            if (!academyRepository.existsByAcademyNumber(number)) {
                return number;
            }
        }
        throw new ResourceConflictException("Failed to generate unique academy number after " + maxAttempts + " attempts");
    }
}
