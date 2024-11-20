CREATE MIGRATION m1wrots7rkjkmpvhb4jwajhlw6swqh62gzbxgeme2vd5c7pxi6nuja
    ONTO m1vvafi2fdm77kmazlhhciu477v6tzmwu4bmufzonn7fn5ieycwfpa
{
  ALTER TYPE default::Invitation {
      ALTER PROPERTY expiresAt {
          SET REQUIRED USING (<std::datetime>{});
      };
      ALTER ACCESS POLICY IAllowUserToSelectItsOwnInvitation USING ((((GLOBAL default::currentUser).email ?= .email) AND (.expiresAt > std::datetime_of_statement())));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationHeHasBeenInvitedTo USING (EXISTS ((SELECT
          default::Invitation
      FILTER
          (((.email = (GLOBAL default::currentUser).email) AND (.organization = default::Organization)) AND (.expiresAt > std::datetime_of_statement()))
      )));
  };
};
