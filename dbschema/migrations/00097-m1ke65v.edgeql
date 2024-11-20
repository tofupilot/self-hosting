CREATE MIGRATION m1ke65vx2wkqxjeiyux4nu2rsfaf2bkrkhjykf7n54sfdwepcm7hsa
    ONTO m1omdwbkiewqy4d3424x3g3lo6y76jzi6qt5i7tapn35rxtkki2pcq
{
  ALTER TYPE default::Invitation {
      CREATE ACCESS POLICY IAllowUserToSelectItsOwnInvitation
          ALLOW SELECT USING (((GLOBAL default::currentUser).email ?= .email));
  };
};
