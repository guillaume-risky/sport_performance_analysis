package com.sportperformance.api.academy;

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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public class AcademyControllerTest extends AbstractIntegrationTest {

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
    public void testCreateAcademy_NonAdmin_Returns403() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";

        insertUser(userId, userNumber, email, "PLAYER", null);

        AcademyRequest request = new AcademyRequest("Test Academy", null, null);
        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, null);

        mockMvc.perform(post("/api/v1/academies")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    public void testCreateAcademy_Admin_Returns200() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "admin@example.com";

        insertUser(userId, userNumber, email, "ACADEMY_ADMIN", null);

        AcademyRequest request = new AcademyRequest("Test Academy", "https://example.com/logo.png", "#112233");
        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.ACADEMY_ADMIN, null);

        mockMvc.perform(post("/api/v1/academies")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.academyNumber").exists())
                .andExpect(jsonPath("$.name").value("Test Academy"))
                .andExpect(jsonPath("$.logoUrl").value("https://example.com/logo.png"))
                .andExpect(jsonPath("$.primaryColor").value("#112233"));
    }

    @Test
    public void testGetMyAcademy_NotSet_Returns404() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";

        insertUser(userId, userNumber, email, "PLAYER", null);
        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, null);

        mockMvc.perform(get("/api/v1/academies/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("ACADEMY_NOT_SET"))
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    public void testGetMyAcademy_AcademyNotFound_Returns404() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";
        Long academyNumber = 999999999L;

        insertUser(userId, userNumber, email, "PLAYER", academyNumber);
        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, academyNumber);

        mockMvc.perform(get("/api/v1/academies/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("ACADEMY_NOT_FOUND"))
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    public void testGetMyAcademy_Set_Returns200() throws Exception {
        Long userId = 1L;
        Long userNumber = 12345L;
        String email = "test@example.com";
        Long academyNumber = 987654321L;

        insertUser(userId, userNumber, email, "PLAYER", academyNumber);
        insertAcademy(academyNumber, "Test Academy", "https://example.com/logo.png", "#112233");
        String token = jwtHelper.createToken(userId, userNumber, email, AppRole.PLAYER, academyNumber);

        mockMvc.perform(get("/api/v1/academies/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.academyNumber").value(academyNumber))
                .andExpect(jsonPath("$.name").value("Test Academy"))
                .andExpect(jsonPath("$.logoUrl").value("https://example.com/logo.png"))
                .andExpect(jsonPath("$.primaryColor").value("#112233"));
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

    private void insertAcademy(Long academyNumber, String name, String logoUrl, String primaryColor) {
        String sql = """
            INSERT INTO academy (academy_number, name, logo_url, primary_color, created_at)
            VALUES (?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            academyNumber,
            name,
            logoUrl,
            primaryColor,
            OffsetDateTime.now()
        );
    }
}
