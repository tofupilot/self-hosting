CREATE MIGRATION m1iv2uf6fsofrfccv4ob4z6hyye5naxg7kg56dlyhyfsfepg2rktwq
    ONTO m1xosadc5c3hmg3ea3zbewpktcdinp7sptrjaqpo3msvprpl6alc7q
{
  ALTER TYPE activity::LabelChange {
      DROP ACCESS POLICY select_if_in_same_org_as_primitive;
      DROP EXTENDING activity::Activity;
      EXTENDING activity::PrimitivePropertyChange LAST;
      ALTER LINK primitive {
          RESET OPTIONALITY;
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE activity::OwnerChange {
      DROP ACCESS POLICY select_if_in_same_org_as_primitive;
      DROP EXTENDING activity::Activity;
      EXTENDING activity::PrimitivePropertyChange LAST;
      ALTER LINK primitive {
          RESET OPTIONALITY;
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE activity::StatusChange {
      DROP ACCESS POLICY select_if_in_same_org_as_primitive;
      DROP EXTENDING activity::Activity;
      EXTENDING activity::PrimitivePropertyChange LAST;
      ALTER LINK primitive {
          RESET OPTIONALITY;
          DROP OWNED;
          RESET TYPE;
      };
  };
};
