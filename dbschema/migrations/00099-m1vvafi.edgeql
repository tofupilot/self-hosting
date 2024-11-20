CREATE MIGRATION m1vvafi2fdm77kmazlhhciu477v6tzmwu4bmufzonn7fn5ieycwfpa
    ONTO m1pkpi26fdijbgvqaj64mpwjxuoqwgdjgt3cjqxyazxsrkvrhratlq
{
  ALTER TYPE default::Invitation {
      CREATE PROPERTY expiresAt: std::datetime {
          CREATE REWRITE
              INSERT 
              USING ((std::datetime_of_statement() + <cal::relative_duration>'30 days'));
          CREATE REWRITE
              UPDATE 
              USING ((std::datetime_of_statement() + <cal::relative_duration>'30 days'));
      };
  };
};
