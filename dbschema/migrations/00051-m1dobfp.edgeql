CREATE MIGRATION m1dobfp6744alahvnxfsuxn3mzoxtmjv6s2ehfb6xtnfnycrnwqg6q
    ONTO m1xjuqqrzayfzogw7dgbrxq74biky34aldlqx7fry3q6zvvhor34ga
{
  CREATE TYPE activity::StatusChange EXTENDING activity::Activity {
      CREATE LINK new -> default::Status {
          SET readonly := true;
      };
      CREATE LINK old -> default::Status {
          SET readonly := true;
      };
      CREATE REQUIRED LINK primitive -> default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
  };
  ALTER TYPE default::Action {
      ALTER LINK parent {
          SET OWNED;
      };
      ALTER LINK parent {
          SET TYPE default::Action USING (.parent[IS default::Action]);
      };
      ALTER LINK template {
          SET OWNED;
      };
      ALTER LINK template {
          SET TYPE default::ActionTemplate USING (.template[IS default::ActionTemplate]);
      };
  };
  ALTER TYPE default::ActionTemplate {
      ALTER LINK parent {
          SET OWNED;
      };
      ALTER LINK parent {
          SET TYPE default::ActionTemplate USING (.parent[IS default::ActionTemplate]);
      };
  };
  ALTER TYPE default::Issue {
      ALTER LINK parent {
          SET OWNED;
      };
      ALTER LINK parent {
          SET TYPE default::Issue USING (.parent[IS default::Issue]);
      };
  };
  ALTER TYPE default::Product {
      ALTER LINK parent {
          SET OWNED;
      };
      ALTER LINK parent {
          SET TYPE default::Product USING (.parent[IS default::Product]);
      };
  };
  ALTER TYPE default::Requirement {
      ALTER LINK parent {
          SET OWNED;
      };
      ALTER LINK parent {
          SET TYPE default::Requirement USING (.parent[IS default::Requirement]);
      };
  };
};
