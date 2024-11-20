CREATE MIGRATION m1povcaokz4mw5iheqqbgwzqbsqyeax4pjo7kl5eaqxdeywbpmumqa
    ONTO m1wrots7rkjkmpvhb4jwajhlw6swqh62gzbxgeme2vd5c7pxi6nuja
{
  ALTER TYPE default::Invitation {
      ALTER ACCESS POLICY IAllowUserToSelectItsOwnInvitation RENAME TO IAllowUserToSelectItsOwnInvitationIfItHasNotExpired;
  };
  ALTER TYPE relation::RequirementToDesign {
      ALTER LINK proofs {
          RENAME TO evidences;
      };
  };
};
