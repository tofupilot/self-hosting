CREATE MIGRATION m1pz6ultt3byificwf3uvgjmbe2gyiayfsynwamafcikrotpppybja
    ONTO m1bro2hhjcsjhruuskkh2ud7nuhyvyfeklcvzyneoxoevcj4ctqljq
{
  ALTER TYPE default::Action {
      ALTER LINK steps {
          ON SOURCE DELETE DELETE TARGET;
      };
  };
  ALTER TYPE default::Primitive {
      DROP PROPERTY archivedAt;
  };
  ALTER TYPE default::FileImport {
      ALTER LINK upload {
          RESET OPTIONALITY;
      };
  };
  ALTER TYPE default::TestStepRun {
      ALTER LINK template {
          ON SOURCE DELETE DELETE TARGET IF ORPHAN;
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE design::Component {
      DROP PROPERTY archivedAt;
  };
  ALTER TYPE design::DesignInstance {
      ALTER PROPERTY numberOfDisplayedSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          FILTER
              (NOT (EXISTS (.parents)) OR EXISTS (.parents.designInstances))
          )) - 1));
      };
      ALTER PROPERTY numberOfSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          )) - 1));
      };
      DROP PROPERTY archivedAt;
  };
  ALTER TYPE design::Revision {
      CREATE LINK image: default::Upload {
          ON TARGET DELETE ALLOW;
      };
  };
};
