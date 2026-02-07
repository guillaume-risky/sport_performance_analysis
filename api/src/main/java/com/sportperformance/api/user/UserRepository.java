package com.sportperformance.api.user;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<User> ROW_MAPPER = (rs, rowNum) -> new User(
        UUID.fromString(rs.getString("id")),
        rs.getString("user_number"),
        rs.getString("academy_id") != null ? UUID.fromString(rs.getString("academy_id")) : null,
        rs.getString("email"),
        rs.getString("role"),
        rs.getBoolean("is_active"),
        rs.getObject("created_at", OffsetDateTime.class)
    );

    public User save(User user) {
        String sql = """
            INSERT INTO app_user (id, user_number, academy_id, email, role, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            RETURNING id, user_number, academy_id, email, role, is_active, created_at
            """;
        
        return jdbcTemplate.queryForObject(sql, ROW_MAPPER,
            user.id(),
            user.userNumber(),
            user.academyId(),
            user.email(),
            user.role(),
            user.isActive(),
            user.createdAt()
        );
    }

    public Optional<User> findByEmail(String email) {
        String sql = """
            SELECT id, user_number, academy_id, email, role, is_active, created_at
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

    public boolean existsByUserNumber(String userNumber) {
        String sql = "SELECT COUNT(*) FROM app_user WHERE user_number = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, userNumber);
        return count != null && count > 0;
    }
}
