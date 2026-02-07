package com.sportperformance.api.testsupport;

import com.sportperformance.api.security.AppRole;
import com.sportperformance.api.security.JwtService;
import com.sportperformance.api.security.SecurityUserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TestJwtHelper {

    @Autowired
    private JwtService jwtService;

    public String createToken(Long userId, Long userNumber, String email, AppRole role, Long academyNumber) {
        String academyNumberStr = academyNumber != null ? academyNumber.toString() : null;
        SecurityUserPrincipal principal = new SecurityUserPrincipal(
            userId,
            userNumber,
            email,
            academyNumberStr,
            role
        );
        return jwtService.issue(principal).token();
    }
}
