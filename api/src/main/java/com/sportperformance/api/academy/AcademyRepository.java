package com.sportperformance.api.academy;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public class AcademyRepository {

    private final JdbcTemplate jdbcTemplate;

    public AcademyRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<Academy> ROW_MAPPER = (rs, rowNum) -> new Academy(
        UUID.fromString(rs.getString("id")),
        rs.getString("academy_number"),
        rs.getString("name"),
        rs.getString("theme_color"),
        rs.getString("logo_url"),
        rs.getObject("created_at", OffsetDateTime.class)
    );

    public Academy save(Academy academy) {
        String sql = """
            INSERT INTO academy (id, academy_number, name, theme_color, logo_url, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            RETURNING id, academy_number, name, theme_color, logo_url, created_at
            """;
        
        return jdbcTemplate.queryForObject(sql, ROW_MAPPER,
            academy.id(),
            academy.academyNumber(),
            academy.name(),
            academy.themeColor(),
            academy.logoUrl(),
            academy.createdAt()
        );
    }

    public Optional<Academy> findByAcademyNumber(String academyNumber) {
        String sql = """
            SELECT id, academy_number, name, theme_color, logo_url, created_at
            FROM academy
            WHERE academy_number = ?
            """;
        
        try {
            Academy academy = jdbcTemplate.queryForObject(sql, ROW_MAPPER, academyNumber);
            return Optional.ofNullable(academy);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public boolean existsByAcademyNumber(String academyNumber) {
        String sql = "SELECT COUNT(*) FROM academy WHERE academy_number = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, academyNumber);
        return count != null && count > 0;
    }
}
