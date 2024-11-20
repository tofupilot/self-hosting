CREATE MIGRATION m1bg4edbul4kotg57mpk7yb75fbw6q3wkio2jiiqjnrk3gueiyn2wa
    ONTO m1h3vugwwnullx26k2wa4kttcwvcsiimjgwismezta2eeqxwcj4mfq
{
  CREATE TYPE activity::EstimatedTimeChange EXTENDING activity::PrimitivePropertyChange {
      CREATE PROPERTY new -> std::duration;
      CREATE PROPERTY old -> std::duration {
          SET readonly := true;
      };
  };
  ALTER TYPE activity::PrimitivePropertyChange {
      ALTER ACCESS POLICY IAllowIfUserInSameOrganizationThanPrimitive ALLOW SELECT, UPDATE;
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK estimatedTimeChanges := (.<primitive[IS activity::EstimatedTimeChange]);
  };
  ALTER TYPE activity::LabelChange {
      ALTER LINK new {
          RESET CARDINALITY USING (SELECT
              .new 
          LIMIT
              1
          );
      };
  };
  ALTER TYPE activity::LabelChange {
      ALTER LINK old {
          RESET CARDINALITY USING (SELECT
              .new 
          LIMIT
              1
          );
      };
  };
  CREATE TYPE activity::NameChange EXTENDING activity::PrimitivePropertyChange {
      CREATE PROPERTY new -> std::str;
      CREATE PROPERTY old -> std::str {
          SET readonly := true;
      };
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK nameChanges := (.<primitive[IS activity::NameChange]);
  };
  CREATE TYPE activity::TargetDateChange EXTENDING activity::PrimitivePropertyChange {
      CREATE PROPERTY new -> std::datetime {
          SET readonly := true;
      };
      CREATE PROPERTY old -> std::datetime {
          SET readonly := true;
      };
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK targetDateChanges := (.<primitive[IS activity::TargetDateChange]);
  };
};
