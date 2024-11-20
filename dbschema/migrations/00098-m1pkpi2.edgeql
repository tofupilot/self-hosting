CREATE MIGRATION m1pkpi26fdijbgvqaj64mpwjxuoqwgdjgt3cjqxyazxsrkvrhratlq
    ONTO m1ke65vx2wkqxjeiyux4nu2rsfaf2bkrkhjykf7n54sfdwepcm7hsa
{
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowUserToSelectOrganizationHeHasBeenInvitedTo
          ALLOW SELECT USING (EXISTS ((SELECT
              default::Invitation
          FILTER
              ((.email = (GLOBAL default::currentUser).email) AND (.organization = default::Organization))
          )));
  };
};
