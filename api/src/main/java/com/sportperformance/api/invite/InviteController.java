package com.sportperformance.api.invite;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/invites")
public class InviteController {

    private final InviteService inviteService;

    public InviteController(InviteService inviteService) {
        this.inviteService = inviteService;
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public InviteResponse createInvite(@Valid @RequestBody InviteRequest request) {
        return inviteService.createInvite(request);
    }

    @GetMapping(value = "/{token}", produces = MediaType.APPLICATION_JSON_VALUE)
    public InviteToken getInvite(@PathVariable String token) {
        return inviteService.getInviteByToken(token);
    }

    @PostMapping(value = "/{token}/accept", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public AcceptInviteResponse acceptInvite(@PathVariable String token, @Valid @RequestBody AcceptInviteRequest request) {
        return inviteService.acceptInvite(token, request);
    }
}
