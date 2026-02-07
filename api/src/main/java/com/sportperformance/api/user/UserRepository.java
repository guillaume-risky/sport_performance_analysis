package com.sportperformance.api.user;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<User> ROW_MAPPER = (rs, rowNum) -> {
        Long academyNumber = rs.getObject("academy_number", Long.class);
        return new User(
            rs.getLong("id"),
            rs.getLong("user_number"),
            rs.getString("email"),
            rs.getString("role"),
            rs.getBoolean("is_active"),
            academyNumber,
            rs.getObject("created_at", OffsetDateTime.class)
        );
    };

    public User save(User user) {
        String sql = """
            INSERT INTO app_user (user_number, email, role, is_active, academy_number, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            RETURNING id, user_number, email, role, is_active, academy_number, created_at
            """;
        
        return jdbcTemplate.queryForObject(sql, ROW_MAPPER,
            user.userNumber(),
            user.email(),
            user.role(),
            user.isActive(),
            user.academyNumber(),
            user.createdAt()
        );
    }

    public Optional<User> findByEmail(String email) {
        String sql = """
            SELECT id, user_number, email, role, is_active, academy_number, created_at
            FROM app_user
            WHERE email = ?
            """;
        
        try {
            User user = jdbcTemplate.queryForObject(sql, ROW_MAPPER, email);
            return Optional.ofNullable(user);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM app_user WHERE email = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, email);
        return count != null && count > 0;
    }

    public boolean existsByUserNumber(Long userNumber) {
        String sql = "SELECT COUNT(*) FROM app_user WHERE user_number = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, userNumber);
        return count != null && count > 0;
    }
}
