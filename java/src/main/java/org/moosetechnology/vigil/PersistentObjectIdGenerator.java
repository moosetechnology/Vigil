package org.moosetechnology.vigil;

import com.fasterxml.jackson.annotation.ObjectIdGenerator;
import java.util.Map;
import java.util.WeakHashMap;

public class PersistentObjectIdGenerator extends ObjectIdGenerator<Long> {
  private static Long SEQ = 1L;
  private static final Map<Object, Long> IDS = new WeakHashMap<>();

  @Override
  public Class<?> getScope() {
    return Object.class;
  }

  @Override
  public ObjectIdGenerator<Long> forScope(Class<?> scope) {
    return this;
  }

  @Override
  public ObjectIdGenerator<Long> newForSerialization(Object context) {
    return this;
  }

  @Override
  public Long generateId(Object forPojo) {
    Long id = IDS.get(forPojo);
    if (id == null) {
      id = SEQ++;
      IDS.put(forPojo, id);
    }
    return id;
  }

  @Override
  public IdKey key(Object key) {
    return new IdKey(getClass(), Object.class, key);
  }

  @Override
  public boolean canUseFor(ObjectIdGenerator<?> gen) {
    return (gen.getClass() == getClass());
  }
}
