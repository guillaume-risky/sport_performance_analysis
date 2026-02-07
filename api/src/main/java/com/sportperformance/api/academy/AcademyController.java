package com.sportperformance.api.academy;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/academies")
public class AcademyController {

    private final AcademyService academyService;

    public AcademyController(AcademyService academyService) {
        this.academyService = academyService;
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public AcademyResponse createAcademy(@Valid @RequestBody AcademyRequest request) {
        return academyService.createAcademy(request);
    }

    @GetMapping(value = "/{academyNumber}", produces = MediaType.APPLICATION_JSON_VALUE)
    public AcademyResponse getAcademy(@PathVariable String academyNumber) {
        return academyService.getAcademyByNumber(academyNumber);
    }
}
