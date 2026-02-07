package com.sportperformance.api.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sportperformance.api.testsupport.AbstractIntegrationTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.jdbc.JdbcTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.Base64;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public class AuthControllerTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    public void setUp() {
        JdbcTestUtils.deleteFromTables(jdbcTemplate, "otp_challenge", "app_user", "user_session", "academy");
    }

    @Test
    public void testVerifyOtp_EndpointHandledByController_Returns400Not404() throws Exception {
        String email = "test@example.com";
        String purpose = "login";
        String invalidOtp = "000000";

        OtpVerifyRequest request = new OtpVerifyRequest(email, purpose, invalidOtp);

        mockMvc.perform(post("/api/v1/auth/otp/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").exists())
                .andExpect(jsonPath("$.correlationId").exists())
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    public void testRequestOtp_Returns200AndStoresOtpRecord() throws Exception {
        String email = "test@example.com";
        String purpose = "login";

        OtpRequest request = new OtpRequest(email, purpose);

        mockMvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("OTP sent successfully"));

        String countSql = "SELECT COUNT(*) FROM otp_challenge WHERE email = ? AND purpose = ?";
        Integer count = jdbcTemplate.queryForObject(countSql, Integer.class, email, purpose);
        assert count != null && count == 1;
    }

    @Test
    public void testVerifyOtp_InvalidOtp_Returns400() throws Exception {
        String email = "test@example.com";
        String purpose = "login";
        String validOtp = "123456";
        String invalidOtp = "000000";
        String codeHash = hashOtp(validOtp);

        insertOtpChallenge(email, purpose, codeHash, false);
        insertUser(email, 1001L);

        OtpVerifyRequest request = new OtpVerifyRequest(email, purpose, invalidOtp);

        mockMvc.perform(post("/api/v1/auth/otp/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("INVALID_OTP"))
                .andExpect(jsonPath("$.correlationId").exists())
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    public void testVerifyOtp_ExpiredOtp_Returns400() throws Exception {
        String email = "test@example.com";
        String purpose = "login";
        String otp = "123456";
        String codeHash = hashOtp(otp);

        insertExpiredOtpChallenge(email, purpose, codeHash);
        insertUser(email, 1001L);

        OtpVerifyRequest request = new OtpVerifyRequest(email, purpose, otp);

        mockMvc.perform(post("/api/v1/auth/otp/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("INVALID_OTP"))
                .andExpect(jsonPath("$.correlationId").exists())
                .andExpect(jsonPath("$.message").value("OTP has expired"));
    }

    @Test
    public void testVerifyOtp_CorrectOtp_Returns200AndToken() throws Exception {
        String email = "test@example.com";
        String purpose = "login";
        String otp = "123456";
        String codeHash = hashOtp(otp);

        insertOtpChallenge(email, purpose, codeHash, false);
        insertUser(email, 1001L);

        OtpVerifyRequest request = new OtpVerifyRequest(email, purpose, otp);

        mockMvc.perform(post("/api/v1/auth/otp/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("OTP verified successfully"))
                .andExpect(jsonPath("$.accessToken").exists())
                .andExpect(jsonPath("$.userNumber").value("1001"));
    }

    private void insertOtpChallenge(String email, String purpose, String codeHash, boolean consumed) {
        String sql = """
            INSERT INTO otp_challenge (id, email, purpose, code_hash, expires_at, attempts, consumed, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            UUID.randomUUID(),
            email,
            purpose,
            codeHash,
            OffsetDateTime.now().plusMinutes(10),
            0,
            consumed,
            OffsetDateTime.now()
        );
    }

    private void insertExpiredOtpChallenge(String email, String purpose, String codeHash) {
        String sql = """
            INSERT INTO otp_challenge (id, email, purpose, code_hash, expires_at, attempts, consumed, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            UUID.randomUUID(),
            email,
            purpose,
            codeHash,
            OffsetDateTime.now().minusMinutes(1),
            0,
            false,
            OffsetDateTime.now().minusMinutes(11)
        );
    }

    private void insertUser(String email, Long userNumber) {
        String sql = """
            INSERT INTO app_user (user_number, email, role, is_active, created_at)
            VALUES (?, ?, ?, ?, ?)
            """;
        jdbcTemplate.update(sql,
            userNumber,
            email,
            "PLAYER",
            true,
            OffsetDateTime.now()
        );
    }

    private String hashOtp(String otp) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(otp.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
