CREATE MIGRATION m12pca645gw2tort2kmbaxqftdya6uhpyb564cjmkb2djes4gzlkwa
    ONTO m1sowouionreep5vdnm4m4slo4o3csygad4r4qmclyceohsg6o5wga
{
  ALTER TYPE design::DesignInstance {
      ALTER PROPERTY numberOfDisplayedSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          FILTER
              ((NOT (EXISTS (.parents)) OR EXISTS (.parents.designInstances)) AND NOT (EXISTS (.archivedAt)))
          )) - 1));
      };
      ALTER PROPERTY numberOfSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          FILTER
              NOT (EXISTS (.archivedAt))
          )) - 1));
      };
  };
};
