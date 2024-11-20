CREATE MIGRATION m1zm2w3bsr3zdv2hjlbuki4jrtg7hvbhmyv3cmaka5olujnbfj7u7q
    ONTO m1agvqp3eevdadqow7sed3wxreri3sivj6lupr24yn7cexkoqmbqxa
{
  ALTER TYPE activity::PrimitivePropertyChange {
      CREATE PROPERTY type := ((std::str_split(.__type__.name, '::'))[1]);
  };
};
