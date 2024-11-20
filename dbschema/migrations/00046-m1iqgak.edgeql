CREATE MIGRATION m1iqgakufiykh3osqugwlwq3ptsbc373h2enrecuwv366pylcuspfa
    ONTO m1otaszhdig3peqe6ijftzcaivdps6ejaw77n6ixwkg4siovnlxxzq
{
  ALTER TYPE default::User {
      ALTER PROPERTY superAdmin {
          SET readonly := true;
      };
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY super_admin_access ALLOW SELECT, DELETE, INSERT;
  };
};
