CREATE MIGRATION m1gs2o5gphmkldlacrs7xnniznd3z3q645pg4opekqs7iqpmviyota
    ONTO m1r7etmdrorcqufixrsy6yabbiulsjfrbcip4ecoznzagcdfjasbgq
{
  CREATE MODULE blog IF NOT EXISTS;
  CREATE ABSTRACT TYPE blog::Permissions {
      CREATE ACCESS POLICY IAllowPublicSelect
          ALLOW SELECT USING (true);
      CREATE ACCESS POLICY IAllowSuperAdminCRUD
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  CREATE TYPE blog::Author EXTENDING blog::Permissions {
      CREATE REQUIRED PROPERTY imageUrl -> std::str;
      CREATE REQUIRED PROPERTY name -> std::str;
      CREATE REQUIRED PROPERTY role -> std::str;
  };
  CREATE SCALAR TYPE blog::PostCategory EXTENDING enum<Company, Product, Technology, Community, Inspiration>;
  CREATE TYPE blog::Post EXTENDING blog::Permissions {
      CREATE REQUIRED LINK author -> blog::Author;
      CREATE REQUIRED PROPERTY category -> blog::PostCategory;
      CREATE PROPERTY content -> std::json;
      CREATE REQUIRED PROPERTY date -> std::datetime {
          SET default := (std::datetime_of_statement());
      };
      CREATE REQUIRED PROPERTY slug -> std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE REQUIRED PROPERTY title -> std::str;
  };
  ALTER TYPE default::Primitive {
      CREATE PROPERTY objectId -> std::int64;
  };
  CREATE TYPE default::Design EXTENDING default::Primitive {
      ALTER LINK parent {
          SET OWNED;
          SET TYPE default::Design USING (<default::Design>{});
      };
  };
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Product, Requirement, Issue, ActionTemplate, Action, Design>;
};
