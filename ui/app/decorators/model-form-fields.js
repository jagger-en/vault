import fieldToAttrs, { expandAttributeMeta } from 'vault/utils/field-to-attrs';
import Model from '@ember-data/model';

/**
 * sets formFields and/or formFieldGroups properties on model class based on attr options
 *
 * propertyNames must be an array of brace expansion supported strings that represent model attr names
 * groupPropertyNames must be an array of objects where the keys represent the group names and the values are propertyNames
 *
 * reference the field-to-attrs util for more information on expected format for fields and groups
 */

export function withFormFields(propertyNames, groupPropertyNames) {
  return function decorator(SuperClass) {
    if (!Object.prototype.isPrototypeOf.call(Model, SuperClass)) {
      // eslint-disable-next-line
      console.error(
        'withFormFields decorator must be used on instance of ember-data Model class. Decorator not applied to returned class'
      );
      return SuperClass;
    }
    return class ModelFormFields extends SuperClass {
      constructor() {
        super(...arguments);
        if (!Array.isArray(propertyNames) && !Array.isArray(groupPropertyNames)) {
          throw new Error(
            'Array of property names and/or array of field groups are required when using withFormFields model decorator'
          );
        }
        if (propertyNames) {
          this.formFields = expandAttributeMeta(this, propertyNames);
        }
        if (groupPropertyNames) {
          this.formFieldGroups = fieldToAttrs(this, groupPropertyNames);
        }
      }
    };
  };
}
