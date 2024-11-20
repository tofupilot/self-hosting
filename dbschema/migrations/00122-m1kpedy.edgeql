CREATE MIGRATION m1kpedybcl6ej6ebtxmekusm47kswlhcyubzat66ibfywgu5w6v2va
    ONTO m1w7jry2uhozos62s5rmnxfvrmc3tt4usqow6wvm2q3ostom6pypnq
{
  ALTER TYPE default::PrimitiveProperty {
      CREATE INDEX ON (.createdAt);
  };
  ALTER TYPE default::Primitive {
      CREATE INDEX ON (.createdAt);
  };
};
