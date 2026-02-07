package com.sportperformance.api.controller;

import java.time.OffsetDateTime;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RootController {

  @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
  public Map<String, Object> root() {
    return Map.of(
      "service", "sport-performance-api",
      "status", "ok",
      "time", OffsetDateTime.now().toString()
    );
  }

  @GetMapping(value = "/health", produces = MediaType.APPLICATION_JSON_VALUE)
  public Map<String, Object> health() {
    return Map.of("status", "ok");
  }
}
