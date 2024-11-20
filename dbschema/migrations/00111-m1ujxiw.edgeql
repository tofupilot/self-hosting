CREATE MIGRATION m1ujxiwyi2ovtjh3tapgjmmqpirblqenfb3f5s3sy73uu3mggh6qra
    ONTO m1j7mk4ymlihgymuth6thzvf6bw574ku4edladvmoxq4qmns2bk4ra
{
  CREATE MODULE view IF NOT EXISTS;
  CREATE ABSTRACT TYPE view::Condition {
      CREATE MULTI LINK filters: std::BaseObject;
      CREATE REQUIRED PROPERTY matchEmptyValues: std::bool;
  };
  CREATE TYPE view::CategoryCondition EXTENDING view::Condition {
      ALTER LINK filters {
          SET MULTI;
          SET OWNED;
          SET TYPE default::Category USING (<default::Category>{});
      };
  };
  CREATE TYPE view::LabelCondition EXTENDING view::Condition {
      ALTER LINK filters {
          SET MULTI;
          SET OWNED;
          SET TYPE default::Label USING (<default::Label>{});
      };
  };
  CREATE TYPE view::StatusCondition EXTENDING view::Condition {
      ALTER LINK filters {
          SET MULTI;
          SET OWNED;
          SET TYPE default::Status USING (<default::Status>{});
      };
  };
  CREATE TYPE view::UserCondition EXTENDING view::Condition {
      ALTER LINK filters {
          SET MULTI;
          SET OWNED;
          SET TYPE default::User USING (<default::User>{});
      };
  };
  CREATE TYPE view::View EXTENDING default::PrimitiveProperty {
      CREATE SINGLE LINK categoryCondition: view::CategoryCondition {
          ON SOURCE DELETE DELETE TARGET;
      };
      CREATE SINGLE LINK labelCondition: view::LabelCondition {
          ON SOURCE DELETE DELETE TARGET;
      };
      CREATE SINGLE LINK statusCondition: view::StatusCondition {
          ON SOURCE DELETE DELETE TARGET;
      };
      CREATE SINGLE LINK userCondition: view::UserCondition {
          ON SOURCE DELETE DELETE TARGET;
      };
      CREATE MULTI LINK projects: default::Project {
          ON TARGET DELETE ALLOW;
      };
      CREATE REQUIRED PROPERTY name: std::str {
          CREATE CONSTRAINT std::max_len_value(50);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE REQUIRED PROPERTY namespace: default::PrimitiveNamespace;
  };
};
