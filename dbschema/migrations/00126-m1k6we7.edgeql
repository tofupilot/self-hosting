CREATE MIGRATION m1k6we7m3uroymfaydtxyqfresxdzfbmbz3hkbe7le5qrmuphcycna
    ONTO m12k7rmog2ndxysm3co7ay5x3zimz7bpl3t34xkgkqftdldlobwcbq
{
  ALTER TYPE design::DesignInstance {
      ALTER PROPERTY numberOfDisplayedSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          FILTER
              ((NOT (EXISTS (.parents)) OR EXISTS (.parents.designInstances)) AND NOT (EXISTS (.revision.archivedAt)))
          )) - 1));
      };
      ALTER PROPERTY numberOfSiblings {
          USING ((std::count((SELECT
              .revision.component.revisions.designInstances
          FILTER
              NOT (EXISTS (.revision.archivedAt))
          )) - 1));
      };
  };
};
