CREATE MIGRATION m1otaszhdig3peqe6ijftzcaivdps6ejaw77n6ixwkg4siovnlxxzq
    ONTO m17jj57ejxg7rewg6jpfkpssfeo22jgsa4z7nv4pafo673tctgv4fa
{
  ALTER TYPE default::Action {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::ActionTemplate {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Issue {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Product {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Requirement {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
