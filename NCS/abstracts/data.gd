@abstract class_name Data extends Resource

@warning_ignore("unused_signal")
signal data_changed

func get_data_uid() -> String:
    return ResourceUID.id_to_text(ResourceLoader.get_resource_uid(self.resource_path))
