const useTriggerOpenAndClose = (controller) => {
  Object.assign(controller, {
    triggerOpen: (eventType = null, targetElement = null, triggerElement = null) => {
      if(!(eventType && targetElement && triggerElement)) return;

      targetElement.dispatchEvent(new CustomEvent(eventType, { detail: { triggerElement } }));
    },

    triggerClose: (eventType = null, targetElement = null) => {
      if(!(eventType && targetElement)) return;

      targetElement.dispatchEvent(new CustomEvent(eventType));
    }
  });
}

export default useTriggerOpenAndClose;
