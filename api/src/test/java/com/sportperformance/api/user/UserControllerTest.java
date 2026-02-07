package com.sportperformance.api.user;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sportperformance.api.security.AppRole;
import com.sportperformance.api.testsupport.AbstractIntegrationTest;
import com.sportperformance.api.testsupport.TestJwtHelper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.jdbc.JdbcTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public class UserControllerTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private TestJwtHelper jwtHelper;

    @BeforeEach
    public void setUp() {
        JdbcTestUtils.deleteFromTables(jdbcTemplate, "otp_challenge", "app_user", "user_session", "academy");
    }

    @Test
    public void testGetMe_Authenticated_Returns200() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";
        Long academyNumber = 987654321L;

        insertUser(userId, userNumber, email, "PLAYER", academyNumber);
        insertAcademy(academyNumber, "Test Academy");

        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, academyNumber);

        mockMvc.perform(get("/api/v1/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userNumber").value(userNumber))
                .andExpect(jsonPath("$.email").value(email))
                .andExpect(jsonPath("$.role").value("PLAYER"))
                .andExpect(jsonPath("$.academyNumber").value(academyNumber));
    }

    @Test
    public void testGetMe_NoAcademy_Returns200WithNullAcademy() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";

        insertUser(userId, userNumber, email, "PLAYER", null);

        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, null);

        mockMvc.perform(get("/api/v1/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userNumber").value(userNumber))
                .andExpect(jsonPath("$.email").value(email))
                .andExpect(jsonPath("$.role").value("PLAYER"))
                .andExpect(jsonPath("$.academyNumber").isEmpty());
    }

    private void insertUser(Long userId, Long userNumber, String email, String role, Long academyNumber) {
        String sql = """
            INSERT INTO app_user (id, user_number, email, role, is_active, academy_number, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            userId,
            userNumber,
            email,
            role,
            true,
            academyNumber,
            OffsetDateTime.now()
        );
    }

    private void insertAcademy(Long academyNumber, String name) {
        String sql = """
            INSERT INTO academy (academy_number, name, logo_url, primary_color, created_at)
            VALUES (?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            academyNumber,
            name,
            null,
            null,
            OffsetDateTime.now()
        );
    }
}
