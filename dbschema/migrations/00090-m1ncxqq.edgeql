CREATE MIGRATION m1ncxqqee265ndejiczy5qtit66s35aja3kdn5hzis4vsknt4l2bva
    ONTO m1bg4edbul4kotg57mpk7yb75fbw6q3wkio2jiiqjnrk3gueiyn2wa
{
  CREATE MODULE design IF NOT EXISTS;
  ALTER TYPE blog::Permissions {
      DROP ACCESS POLICY IAllowPublicSelect;
      DROP ACCESS POLICY IAllowSuperAdminCRUD;
  };
  ALTER TYPE blog::Author {
      DROP PROPERTY imageUrl;
      DROP PROPERTY name;
      DROP PROPERTY role;
  };
  DROP TYPE blog::Post;
  DROP TYPE blog::Author;
  DROP TYPE blog::Permissions;
  CREATE TYPE default::Category EXTENDING default::PrimitiveProperty {
      CREATE LINK parent -> default::Category {
          ON TARGET DELETE ALLOW;
      };
      CREATE MULTI LINK children := (.<parent[IS default::Category]);
      CREATE REQUIRED LINK project -> default::Project;
      CREATE REQUIRED PROPERTY name -> std::str {
          CREATE CONSTRAINT std::max_len_value(50);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE REQUIRED PROPERTY namespace -> default::PrimitiveNamespace;
  };
  ALTER TYPE default::Primitive {
      CREATE LINK category -> default::Category {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::Primitive {
      CREATE PROPERTY detailedNamespace := ((std::str_split(.__type__.name, '::'))[1]);
      ALTER PROPERTY namespace {
          USING (('Design' IF (.detailedNamespace IN {'Revision', 'Instance'}) ELSE .detailedNamespace));
      };
  };
  ALTER TYPE default::Asset {
      ALTER LINK template {
          SET OWNED;
      };
  };
  ALTER TYPE default::Asset {
      ALTER LINK template {
          SET TYPE default::Design USING (.template[IS default::Design]);
      };
  };
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY IAllowSuperAdminToSelectAllOrganizationsForAnalytics;
  };
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectAllOrganizationsForAnalyticsAndUpdateThem
          ALLOW SELECT, UPDATE USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE MULTI LINK projects := (.<organization[IS default::Project]);
      CREATE PROPERTY slug -> std::str {
          CREATE CONSTRAINT std::exclusive;
          CREATE CONSTRAINT std::max_len_value(50);
          CREATE CONSTRAINT std::min_len_value(1);
          CREATE CONSTRAINT std::regexp('^[a-z0-9-]+$');
      };
  };
  CREATE TYPE design::Component EXTENDING default::PrimitiveProperty {
      CREATE REQUIRED MULTI LINK projects -> default::Project;
      CREATE REQUIRED PROPERTY name -> std::str {
          CREATE CONSTRAINT std::max_len_value(100);
      };
  };
  ALTER TYPE default::Project {
      CREATE MULTI LINK components := (.<projects[IS design::Component]);
  };
  CREATE TYPE design::Revision EXTENDING default::Design {
      CREATE REQUIRED LINK component -> design::Component {
          ON SOURCE DELETE DELETE TARGET IF ORPHAN;
      };
  };
  ALTER TYPE design::Component {
      CREATE MULTI LINK revisions := (.<component[IS design::Revision]);
  };
  CREATE TYPE design::DesignInstance EXTENDING default::PrimitiveProperty {
      CREATE MULTI LINK parents -> design::Revision {
          ON TARGET DELETE ALLOW;
      };
      CREATE REQUIRED LINK revision -> design::Revision {
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE REQUIRED PROPERTY name -> std::str {
          CREATE CONSTRAINT std::max_len_value(100);
      };
  };
  ALTER TYPE design::Revision {
      CREATE MULTI LINK designInstances := (.<revision[IS design::DesignInstance]);
      CREATE MULTI LINK childrenDesignInstances := (.<parents[IS design::DesignInstance]);
  };
  ALTER TYPE design::Component {
      CREATE PROPERTY numberOfParents := (std::count((SELECT
          .revisions.designInstances
      FILTER
          EXISTS (.parents)
      )));
  };
  ALTER TYPE release::Permissions {
      DROP ACCESS POLICY IAllowPublicSelect;
      DROP ACCESS POLICY IAllowSuperAdminCRUD;
  };
  ALTER TYPE release::Release {
      DROP LINK highlights;
      DROP PROPERTY content;
      DROP PROPERTY date;
      DROP PROPERTY version;
  };
  DROP TYPE release::Highlight;
  DROP TYPE release::Release;
  DROP TYPE release::Permissions;
  DROP SCALAR TYPE blog::PostCategory;
  DROP SCALAR TYPE release::HighlightCategory;
  DROP MODULE blog;
  DROP MODULE release;
};
