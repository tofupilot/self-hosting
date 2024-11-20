CREATE MIGRATION m1agvqp3eevdadqow7sed3wxreri3sivj6lupr24yn7cexkoqmbqxa
    ONTO m1iv2uf6fsofrfccv4ob4z6hyye5naxg7kg56dlyhyfsfepg2rktwq
{
  ALTER TYPE activity::LabelChange {
      DROP PROPERTY type;
  };
  ALTER TYPE activity::OwnerChange {
      DROP PROPERTY type;
  };
  ALTER TYPE activity::StatusChange {
      DROP PROPERTY type;
  };
};
