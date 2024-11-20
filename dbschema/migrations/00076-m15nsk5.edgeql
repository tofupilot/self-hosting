CREATE MIGRATION m15nsk5wv2kwwjlv4kiupmt5pzfdefkqhuloxepqjgvzxapblbaila
    ONTO m16afmrnf3goaxwx43ky37q6e7ptjhpt66jtkawuivq7iyammou4eq
{
  CREATE GLOBAL default::isTiptapServer -> std::bool {
      SET default := false;
  };
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowTiptapServerToUpdate
          ALLOW UPDATE USING ((GLOBAL default::isTiptapServer ?? false));
  };
};
